#!/bin/bash
# AWS Deep Learning Jupyter Notebook Server



##-------------------------------------##
## AWS EC2 Parameters (EDITS REQUIRED) ##
##-------------------------------------##

# CHANGE THE PARAMETERS BELOW TO FIT YOUR PROJECT
KEY="merlin" # (Change) your aws keypair file name sans the ".pem"

INSTANCE_TYPE="t2.micro" # (Optional Change) small to start with, move to bigger like c4.8xlarge when needed
PORT="8888" # (Optional Change) the localhost port where your jupyter notebook will be served, 
            #  cannot be your current local jupyter notebook server port
IMAGEID="ami-f1e73689" # (Don't Change) Deep Learning AMI with Conda (Ubuntu)
COUNT="1" # (Don't Change) Number of instances to create
REGION="us-west-2" # (Don't change if you are in Seattle!)
USER="ubuntu" # (Don't Change)the EC2 linux user name
UD="" # supposed to be boot script but doesn't seem to work. Solution, use AMI with everything preinstalled
#UD="--user-data file://$HOME/scripts/aws/start.txt"
BDM="--block-device-mappings file://mappings.json"



##------------------------##
## Start AWS EC2 Instance ##
##------------------------##

# start EC2 instance using above parameters
# and save instance id to variable INSTANCE
INSTANCE="$(aws ec2 run-instances --image-id $IMAGEID --instance-type $INSTANCE_TYPE --count $COUNT --key-name $KEY --region $REGION --query 'Instances[0].InstanceId' $BDM $UD)"

# remove quotes around INSTANCE id
INSTANCE="${INSTANCE%\"}"
INSTANCE="${INSTANCE#\"}"



##-----------------##
## Verify Instance ##
##-----------------##

# seems to take about 3 to 4 minutes for SSH fingerprints to show
# up in the output. wait for 2 and a half minutes, then start polling output
#echo $'\n'
echo "Waiting for $INSTANCE to boot"
echo ""

i=0
while [ 1 ]
do

FINGERPRINTS=$(aws ec2 get-console-output --instance-id $INSTANCE | egrep -m 1 -o '([0-9a-f][0-9a-f]:){15}[0-9a-f][0-9a-f]')

SSH_SERVER_KEY=$(aws ec2 get-console-output --instance-id $INSTANCE | sed -n 's/^.*nssh-rsa //p' | sed 's/ root@ip-.*$//g')


# Check for FINGERPRINT every ~10 seconds (9 + runtime)
# Print "Booting..." every 60 seconds
	if [ "$FINGERPRINTS" = "" ];then
		sleep 9
		i=`expr $i + 1`
		m=`expr $i % 6`
		if [ "$m" -ne 0 ]
		then
			continue
		fi
		n=$(( i / 6 ))
		echo "Booting...($n min)"
	else
		break
	fi
done
echo ""
echo "Expected fingerprints are $FINGERPRINTS"

# get hostname for the instance
HOST=$(aws ec2 describe-instances | grep -m 1 us-west-2.compute.amazonaws.com | egrep -o 'ec2(-[0-9]+){4}.us-west-2.compute.amazonaws.com')
HOST_IP=$(echo "$HOST" | sed "s/ec2-//g;s/\..*//g;s/-/./g")
HOST_ALIAS="aws-ec2"
echo "Host is $HOST located at $HOST_IP"

#cat host.key >> ~/.ssh/known_hosts 2>/dev/null

# Read the private OpenSSH format from the *.pem file and output public key to host.key
ssh-keygen -yf $KEY.pem > host.key
# Output the fingerprint of the specified public key to host.fingerprint.
ssh-keygen -lf host.key > host.fingerprint
# Store fingerprint from host.fingerprint into bash var for printing
read len ACTUAL_FINGERPRINTS host rsa < host.fingerprint
echo "Actual fingerprints are $ACTUAL_FINGERPRINTS"

if [ "$ACTUAL_FINGERPRINTS" = "$FINGERPRINTS" ];then

echo "Fingerprints match, adding to known hosts"
echo "Connecting..."
echo ""



### At this point the instance has been started, it has completed 
### booting, ssh fingerprints have been validated. Next step is to 
### store the credentials in known_hosts in your ~/.ssh folder



##-------------------##
## Store Credentials ##
##-------------------##

# Removes ec2* line(s) in known_hosts (e.g. from the last ec2 instance)
sed -i '' '/^ec2/d' ~/.ssh/known_hosts

# Make known_hosts entry from "HOST,HOST_IP ssh-rsa SSH_SERVER_KEY'
# and store in server.key
echo "$HOST,$HOST_IP ssh-rsa $SSH_SERVER_KEY" > server.key

## Optional: Hash server key in known hosts
#ssh-keygen -q -f -H server.key

# Add server.key to known_hosts
cat server.key >> ~/.ssh/known_hosts 2>/dev/null

# Delete copies of ssh server key
gshred -u server.key host.key host.fingerprint



##-------------##
## Upload Data ##
##-------------##

echo "Uploading Data"
echo ""

# Copy jupyter custom config files to instance
scp -i $KEY.pem -rq ~/.jupyter ubuntu@$HOST:~/.jupyter

# # Copy installation script to instance since --data-file just hangs 
# scp -i $KEY.pem ~/scripts/aws/start.txt ubuntu@$HOST:~/start

# # Copy data files to instance
# scp -i $KEY.pem -r ~/data ubuntu@$HOST:~/data



##------------------##
## Ready to Connect ##
##------------------##

echo ""
echo ""
echo ""
echo "Ready to connect"
echo ""
echo ""
echo "  In terminal run:"
echo ""
echo "    ssh -i merlin.pem -L $PORT:127.0.0.1:8888 $USER@$HOST"
echo ""
echo ""
echo "  Then in terminal run:"
echo ""
echo "    jupyter notebook"
echo ""
echo ""
echo "  Then in local browser:"
echo ""
echo "    Jupyter notebook server available @ http://localhost:$PORT"

else

echo "Fingerprints do not match"

fi

