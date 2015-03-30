The default build on OS X 10.9.5 results in the following error:

 workcycleObjectDetectorFunction: ERROR: Exception caught: 
'unique_lock::lock: already locked: Resource deadlock avoided'

This seems to be due to improper use of unique_lock<std::mutex>, 
where that is maintained as a member variable instead of relying on scope based locking (per design).
