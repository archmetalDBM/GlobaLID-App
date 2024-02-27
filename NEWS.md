# Version 1.1 (in progress)

## Enhancements

* Links open now in a new tabs/windows. Exception: Links that are displayed as their URL. In these cases automatic link detection overwrites it to the default behaviour (open in same tab).  (#4)
* Data can be subset based on tectonic/geological information via Tectonic/geol. super unit/unit/sub unit and deposit type (#8). 
* The upload page contains now a tab "Instructions" with detailed information about the file structure of files suitable for upload and hints for troubleshooting (#6)

## Bugfixes

* Slider for point and line size now allow also values between 0 and 1. 
* Downloads of enhanced uploaded data and dataset now consistently do not include row numbers and leave empty cells empty instead of filling them with "NA".
* txt format output of the references now has line breaks working on Windows. 
* Uploaded data are not displayed on the map anymore after resetting them
* The detection pattern of the function `LI_ratios_all()` was improved. 

# Version 1.0 

* Publication of the GlobaLID web application