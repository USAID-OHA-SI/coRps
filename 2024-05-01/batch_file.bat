REM hide commands
@echo off

REM Define the path to Rscript executable
set "rscript=C:\Program Files\R\R-4.3.2\bin\Rscript.exe"


REM Common path for all scripts - adjust this to your local path
set "common_path=C:\Users\ksrikanth\Documents\Github\coRps\2024-05-01\Scripts\"

REM Define the path to the R script
set "rscript_file1=%common_path%script_1.R"
set "rscript_file2=%common_path%script_2.R"
set "rscript_file3=%common_path%script_3.R"


REM Execute the R script
"%rscript%" "%rscript_file1%"
"%rscript%" "%rscript_file2%"
"%rscript%" "%rscript_file3%"

REM  see how code was executed.  Use EXIT to close this instead
PAUSE