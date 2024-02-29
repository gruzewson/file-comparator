#!/bin/bash

################################################################################
# Author       : Marcel Grużewski (s193589@student.pg.edu.pl)
# Created on   : 20.04.2023
# Last Modified By: Marcel Grużewski (s193589@student.pg.edu.pl)
# Last Modified On: 24.05.2023
# Version      : 1.0
#
# Description  : This Bash script allows a user to compare txt files, bash scripts and folders.
#                It provides a menu of options to choose waht we want to compare,
#                with showing differences option.
#                It checks if the following files/folders are different without white signs.
#                It uses zenity for grapgic representaion and diff to compare files.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact the Free Software Foundation for a copy)
################################################################################

DIRECTORY="Pobrane"

function choose_option() 
{
  checkbox_value=false

  choice=$(zenity --question --title="Show Differences" \
    --text="Do you want to see the differences in files?" \
    --ok-label="Yes" \
    --cancel-label="No")

  if [ $? = 0 ]; then
    checkbox_value=true
  else
    checkbox_value=false
  fi

  echo $checkbox_value
}

function compare_files() 
{
  show_diff=$1
  file1=$2
  file2=$3
  name=$4
  # Check if files exist
  if [ ! -f "$file1" ] || [ ! -f "$file2" ] || [ -z "$file1" ] || [ -z "$file2" ]; then
    zenity --error --title="information" --text="The specified files do not exist."
    return
  fi

  result=$(diff --ignore-space-change $file1 $file2)

  if [ $? -eq 0 ]; then
    zenity --info --title="information" --text="The $name are identical."
  else
    if [ "$show_diff" == "true" ]; then
      echo -e "$result" | zenity --text-info --title="Differences in $name" --width=500 --height=700 --cancel-label="Close"

    else
      zenity --info --title="information" --text="The $name are different."
    fi
  fi
}

while true; do
  choice=$(zenity --list --title "Choose an option" --width=400 --height=300 \
    --text "What would you like to do?" \
    --column "No." --column "Options" \
    1 "Compare txt files" \
    2 "Compare script results" \
    3 "Compare folders" \
    --cancel-label=Cancel)

  if [[ $? == 1 ]]; then
    break
  fi

  case $choice in
    "1")
      show_diff=$(choose_option)
      file_names=$(zenity --forms \
        --title="Enter file names" --width=400 --height=300 \
        --text="Enter file names (without .txt):" \
        --add-entry="First file name" \
        --add-entry="Second file name" \
        --cancel-label=Cancel)

      file1=$(echo "$file_names" | cut -d '|' -f 1)
      file2=$(echo "$file_names" | cut -d '|' -f 2)
      compare_files "$show_diff" "$file1.txt" "$file2.txt" "files"
      ;;
    "2")
      show_diff=$(choose_option)
      script_names=$(zenity --forms \
        --title="Enter script names" --width=400 --height=300 \
        --text="Enter script names (without .sh):" \
        --add-entry="First script name" \
        --add-entry="Second script name" \
        --cancel-label=Cancel)

      script1=$(echo "$script_names" | cut -d '|' -f 1)
      script2=$(echo "$script_names" | cut -d '|' -f 2)
      script1="./$script1.sh"
      script2="./$script2.sh"

      # Check if files exist
      if [[ ! -f "$script1" ]] || [[ ! -f "$script2" ]]; then
        zenity --error --title="information" --text="Invalid input."
        break
      fi

      touch temp1.txt
      touch temp2.txt

      bash "$script1" > temp1.txt
      bash "$script2" > temp2.txt

      compare_files "$show_diff" "temp1.txt" "temp2.txt" "script results"
      rm "temp1.txt"
      rm "temp2.txt"
  ;;
"3")
  show_diff=$(choose_option)
  folder_names=$(zenity --forms \
    --title="Enter folder names" --width=400 --height=300 \
    --text="Enter folder names:" \
    --add-entry="First folder name" \
    --add-entry="Second folder name" \
    --cancel-label=Cancel)

  folder1=$(echo "$folder_names" | cut -d '|' -f 1)
  folder2=$(echo "$folder_names" | cut -d '|' -f 2)

  # Check if entered folders exist
  if [[ ! -d "$folder1" ]] || [[ ! -d "$folder2" ]]; then
    zenity --error --title="information" --text="Invalid input."
    break
  fi

  touch temp1.txt
  touch temp2.txt

  ls ~/"$DIRECTORY/$folder1" > "temp1.txt"
  ls ~/"$DIRECTORY/$folder2" > "temp2.txt"

  compare_files "$show_diff" "temp1.txt" "temp2.txt" "folders"

  rm temp1.txt
  rm temp2.txt
  ;;
*)
  zenity --error --title="information" --text="No option selected."
  ;;
  esac

break
done