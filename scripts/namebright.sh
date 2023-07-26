#!/bin/bash

# bash/curl examples for interacting with the NameBright Domain API using the REST endpoints.

set -e
source auth/namebright-api.env

# get a token from the API
export token=`curl -d grant_type=client_credentials -d client_id="$namebright_client_id" --data-urlencode client_secret="$namebright_secret" https://api.namebright.com/auth/token | sed  's/{"access_token":"\([^"]*\).*/\1/'`
echo "${token: -20}"

#list the host records
list-records() {
    curl -i -H "Authorization: Bearer $token" https://api.namebright.com/rest/account/domains/techig.com/hostrecords
}

#create a new host record with POST data (application/x-www-form-urlencoded)
create-record() {
    curl -i -H "Authorization: Bearer $token" -d Subdomain=foo -d IPV4Address=123.123.123.123 https://api.namebright.com/rest/account/domains/techig.com/hostrecords/a
}

#delete the record by id
delete-record() {
    curl -i -X DELETE -H "Authorization: Bearer $token" https://api.namebright.com/rest/account/domains/techig.com/hostrecords/txt/9100
}

#add a nameserver to a domain. Note: curl doesn't send Content-Length when no message body is present so we
#need to do this ourselves:
add-nameserver() {
    curl -i -X PUT -H "Authorization: Bearer $token" -H "Content-Length: 0" https://api.namebright.com/rest/account/domains/techig.com/nameservers/ns1.namebrightdns.com
}

$1

# #change contact info
# curl -i -X PUT -H "Authorization: Bearer $token" -d Phone=303.555.1234 -d PostalCode=80203 -d FirstName=John -d LastName=Doe -d Email=johndoe@techig.com -d "Address1=200 East Colfax Avenue" -d City=Denver -d Region=CO -d Country=US https://api.namebright.com/rest/account/domains/techig.com/contacts/technical

# #change locking, auto-renew, or whois privacy
# curl -i -X PUT -H "Authorization: Bearer $token" -d DomainName=techig.com -d Status=active -d ExpirationDate=2017-05-06T00:00:00 -d Locked=true -d AutoRenew=false -d WhoIsPrivacy=true -d "Category=Default Category" -d UpgradedDomain=false https://api.namebright.com/rest/account/domains/techig.com
