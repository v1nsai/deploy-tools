#!/bin/bash

ssh -i ~/.ssh/doctor_ew -o StrictHostKeyChecking=no -p $2 $1
