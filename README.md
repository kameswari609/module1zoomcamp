ANSWER 1- pip 25.3 from /usr/local/lib/python3.13/site-packages/pip (python 3.13)

answer 3 - could not find a 2025-11 file in the DataTalksClub release assets, so used the official TLC parquet file (https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-11.parquet). The count of trips with trip_distance <= 1 is 989,009.

answer 4 -The pickup day is 2025-11-21 (max trip_distance under 100 miles: 99.81)

answer 5 -Pickup zone with the largest total_amount is JFK Airport (sum: 370,682.26).
 answer 6 -The drop‑off zone is East Harlem North (max tip: 50.0).



TERRAFORM MODULE 1 IN GCP SUCCESSFULLY APPLIED FROM LOCAL


Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_storage_bucket.zoomcamp2026-module1-bucketname: Creating...
google_storage_bucket.zoomcamp2026-module1-bucketname: Creation complete after 1s [id=module1-zoomcamp-bucket]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed




