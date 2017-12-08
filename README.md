# AWS Jupyter notebook server

Jupyter notebook that:

```
* Starts a Jupyter notebook server on AWS EC2

* Does a secure fingerprint handshake to avoid any Man-in-the-middle attacks

* Returns the long and complicated ssh login command for easy copy/paste into terminal

* Returns intructions on how to start jupyter on remote server and easily open it in a browser

* Returns intructions with commands to terminate instance (i.e. stop paying for it!)
```

## Getting Started

These instructions will get a copy of the notebook and/or script running on your local machine for testing purposes.

### Prerequisites

Python dependancies
```
python==3.6.0 or above
jupyter==1.0.0
```


Additional requirements
```
1. *.pem security file from AWS must be in the same folder as the notebook or script

2. mappings.json file must be in the same folder as the notebook or script
```


### Running

```
Execute first code cell in *.ipynb or run bash script on command line
```

### Expected output (*ipynb does not print as it goes like the script does. It only prints out when done running)

```
Waiting for i-014f48f62eb841fa1 to boot

Booting...(1 min)
Booting...(2 min)
Booting...(3 min)
Booting...(4 min)
                          
Expected fingerprints are d4:26:c0:7c:77:b1:63:ff:01:37:48:ad:2b:23:c5:4d
Host is ec2-52-41-173-172.us-west-2.compute.amazonaws.com located at 52.41.173.172
Actual fingerprints are d4:26:c0:7c:77:b1:63:ff:01:37:48:ad:2b:23:c5:4d
Fingerprints match, adding to known hosts
Connecting...

Uploading Data



Ready to connect


  In a terminal run:

    ssh -i $KEY_LOC/$KEY.pem -L $PORT:127.0.0.1:8888 ubuntu@ec2-52-41-173-172.us-west-2.compute.amazonaws.com


  Then in the same terminal run:

    jupyter notebook


  Then in the same terminal:

    (CMD + click) on the http://localhost:8888?token..... link

```

### Terminating

To end session cleanly, run the following in a terminal window:

```
aws ec2 terminate-instances --instance-ids $INSTANCE_ID   
```

The $INSTANCE_ID should be part of the script output



## Authors

* **Andrew T. Crooks** - [Github](https://github.com/andrewtcrooks)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details