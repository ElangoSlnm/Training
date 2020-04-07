# !/bin/bash

# Pg_dump Aruguments
host='hostname'
username='dbuser'
password='dbpass'
database='dbnamer'
path='/path/to/place/dump'

# AWS S3 parameters
s3Bucket="S3bucketname"
s3AccessKey="accessKey"
s3SecretKey="secretKey"
relativePath="dirname"

# Mail parameters

#Logs file
logs_file="$path/logs"
if [ ! -e "$logs_file" ] ; then
    touch $logs_file
fi

# Dump Database
dumpDB() {

    filename="dump_name_$(date +%d_%b_%Y).tar"
    filepath="$path/$filename"

    if [ -z "$host" ] || [ -z "$username" ] || [ -z "$password" ] || [ -z "$database" ]; then
        echo $(date) 'Pg_dump arguments missing.!' >> $logs_file
    elif [ -d "$path" ]; then
        PGPASSWORD=$password pg_dump -U $username -h $host -w -F t $database > $filepath
        pushS3
    else echo $(date) "$path directory doesn't exist." >> $logs_file
    fi
}

# Push dump_file to S3 Bucket
pushS3() {

    relativePath="$relativePath/$filename"
    contentType="application/octet-stream"
    date="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
    
    if [ -z "$s3Bucket" ] ||  [ -z "$s3AccessKey" ] || [ -z "$s3SecretKey" ] || [ -z "$relativePath" ]; then
        echo $(date) 'S3 bucket arguments missing.' >> $logs_file
    elif [ -f "$filepath" ]; then
        echo $(date) "$database database dumped" >> $logs_file
        md5="$(openssl md5 -binary < "$filepath" | base64)"
        signature="$(printf "PUT\n$md5\n$contentType\n$date\n/$s3Bucket/$relativePath" | openssl sha1 -binary -hmac "$s3SecretKey" | base64)"

        curl -T $filepath -H "Date: $date" \
            -H "Authorization: AWS $s3AccessKey:$signature" \
            -H "Content-Type: $contentType" \
            -H "Content-MD5: $md5" \
            https://$s3Bucket.s3.amazonaws.com/$relativePath
        echo $(date) "$filename Dump file pushed to S3 Bucket" >> $logs_file
        sendMail
    else echo $(date) "$filepath file doesn't exist." >> $logs_file
    fi
}

#Send Notification mail
sendMail() {
    
    size=$(du --si "$filepath" | awk '{print $1}')

    sname="sendername"
    from="sender@gmail.com"
    to="receiver@gmail.com"
    subject="Notification mail for S3 Bucket Snapshot"
    body="
Hi All,

S3 Bucket snapshot has been pushed successfully, please find below attached file.

File Details:
Name: $filename
Size: $size
Link: https://s3.console.aws.amazon.com/s3/buckets/pramati-hrms-app/teamtracker/?region=us-east-1
"
    if [ -z "$from" ] ||  [ -z "$to" ] || [ -z "$subject" ] || [ -z "$body" ]; then
        echo $(date) 'Mail arguments missing.' >> $logs_file
    elif [ -f "$filepath" ]; then
        mail -s "$subject" -a "From: $sname <$from>" \
            --content-type=application/x-tar \
            --content-filename="$filename" --attach="$filepath" $to \
            --content-type=text/plain <<< "$body"
        echo $(date) "Notification mail sent" >> $logs_file
    else echo $(date) "$filepath file doesn't exist." >> $logs_file
    fi

}

dumpDB