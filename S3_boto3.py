import boto3
session = boto3.Session(profile_name='default')
s3_re = session.resource('s3', region_name='us-east-1')
bucket = s3_re.create_bucket(Bucket='terraform-vedank-bucket')

response = bucket.create(
    ACL='private'
)



for obj in bucket.objects.all():
    print(obj.key)

