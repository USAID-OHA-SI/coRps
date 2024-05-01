REM hide commands
@echo off

REM Define the path to Rscript executable
set "rscript=C:\Program Files\R\R-4.3.3\bin\Rscript.exe"


REM Common path for all scripts
set "common_path=C:\Users\kirst\Sync\Projects\run_r_with_bat_file\Scripts\"

REM Define the path to the R script
set "rscript_file1=%common_path%script_1.R"
set "rscript_file2=%common_path%script_2.R"
set "rscript_file3=%common_path%script_3.R"
set "rscript_file4=%common_path%script_4.R"
set "rscript_file5=%common_path%script_5.R"


REM Execute the R script
"%rscript%" "%rscript_file1%"
"%rscript%" "%rscript_file2%"
"%rscript%" "%rscript_file3%"
"%rscript%" "%rscript_file4%"
"%rscript%" "%rscript_file5%"

REM  see how code was executed.  Use EXIT to close this instead
PAUSE