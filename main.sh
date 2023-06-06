#!/bin/bash

function createDB {
  echo -e "\nCreating a new database...\n"
  echo -e "\nEnter '!' to return.\n"
  echo -e "Enter Database Name: \c"
  read dbName
      if [ "$dbName" = "!" ]; then
        menuOptions
        return
    fi
      if [[ ! $dbName =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid database name. Please try again."
        createDB
    fi
  mkdir ./$dbName
  if [[ $? == 0 ]]
  then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database $dbName"
  fi
  menuOptions
}

function removeDB() {
  echo -e "\nEnter the database file name (or ! to return): \c"
  read dirname
      if [ "$dirname" = "!" ]; then
        menuOptions
        return
    fi
  if [ -d "$dirname" ]; then
    rm -r "$dirname"
    echo -e "\nDatabase file '$dirname' has been removed.\n"
    menuOptions
    return
  else
    echo -e "\nNo such database exists.\n"
  fi
  removeDB
}

function createTable(){
echo -e "Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "Table already exists"
    createTable
    return
  elif [[ ! $tableName =~ ^[a-zA-Z]+$ ]]; then
        echo "Invalid table name. Please try again."
        createTable
        return
  fi
  echo -e "Number of Columns: \c"
  read colsNum
  if ! [[ $colsNum =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a number."
        createTable
        return
    elif (( $colsNum < 1 || $colsNum > 20 )); then
        echo "Invalid Input. Please enter a number between 1 and 20."
        createTable
        return
    fi
  counter=1
  sep="|"
  rSep="\n"
  metaData="Field"$sep"Type"$sep"key"
  while [ $counter -le $colsNum ]
  do
    echo -e "Name of Column No.$counter: \c"
    read colName

    echo -e "Type of Column $colName: "
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done
    if [[ "$counter" -eq 1 ]]; then
        metaData+=$rSep$colName$sep$colType$sep$"PK";
    else
        metaData+=$rSep$colName$sep$colType$sep""
    fi
    if [[ $counter == $colsNum ]]; then
      temp=$temp$colName
    else
      temp=$temp$colName$sep
    fi
    ((counter++))
  done
  touch .$tableName
  echo -e $metaData  >> .$tableName
  touch $tableName
  echo -e $temp >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Table Created Successfully"
  else
    echo "Error Creating Table $tableName"
  fi
  printDBmenu
}

function dropTable(){
  echo -e "Enter Table Name: \c"
read tableName
    rm $tableName .$tableName
  if [[ $? == 0 ]]; then
    echo "Table Dropped Successfully"
  else
    echo "Table Not found"
  fi
  printDBmenu
}

function insertToTable(){
# Prompt the user for the table name
echo -e "Table Name: \c"
read tableName

# Check if the table file exists
if ! [[ -f $tableName ]]; then
  # If it doesn't exist, print an error message and call the printDBmenu function
  echo "Table $tableName doesn't exist!"
  printDBmenu
# Check if the table name contains only letters
elif [[ ! $tableName =~ ^[a-zA-Z]+$ ]]; then
  # If it contains non-letter characters, print an error message and call the printDBmenu function
  echo "Table name can only contain letters!"
  printDBmenu
fi

# Get the number of columns in the table
colsNum=`awk 'END{print NR}' .$tableName`

# Set the column and row separators
sep="|"
rSep="\n"

# Loop through each column
for (( i = 2; i <= $colsNum; i++ )); do
  # Get the column name, type, and key from the table file
  colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
  colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
  colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)

  # Prompt the user for data input for the column
  echo -e "$colName ($colType) = \c"
  read data

  # Validate the input based on the column type
  if [[ $colType == "int" ]]; then
    # If the column type is "int", check if the input is a valid integer
    while ! [[ $data =~ ^[0-9]*$ ]]; do
      echo -e "invalid DataType !!"
      echo -e "$colName ($colType) = \c"
      read data
    done
  fi

  # Validate the input based on the column key
  if [[ $colKey == "PK" ]]; then
    # If the column key is "PK", check if the input is unique
    while [[ true ]]; do
      if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
        echo -e "invalid input for Primary Key !!"
      else
        break;
      fi
      echo -e "$colName ($colType) = \c"
      read data
    done
  fi

  # Set the row data
  if [[ $i == $colsNum ]]; then
    # If this is the last column, add the row separator to the end of the row data
    row=$row$data$rSep
  else
    # Otherwise, add the column separator to the end of the row data
    row=$row$data$sep
  fi
done

# Append the row data to the table file
echo -e $row"\c" >> $tableName

# Print a success or error message based on the outcome of the appending operation
if [[ $? == 0 ]]
then
  echo "Data Inserted Successfully"
else
  echo "Error Inserting Data into Table $tableName"
fi

# Reset the row data and call the printDBmenu function
row=""
printDBmenu

}

function deleteFromTable() {
  echo -e "Enter Table Name: \c"
  read tName
    if ! [[ -f $tName ]]; then
    echo "Table $tName doesn't exist!"
    deleteFromTable
  elif [[ ! $tName =~ ^[a-zA-Z]+$ ]]; then
  echo "Table name can only contain letters!"
  deleteFromTable
  fi
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
    else
      NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
      sed -i ''$NR'd' $tName 2>>./.error.log
      echo "Row Deleted Successfully"
fi
fi
printDBmenu
}

function updateTable {
  echo -e "Enter Table Name: \c"
  read tName
if ! [[ -f $tName ]]; then
    echo "Table doesn't Exist"
    updateTable
    return
  fi
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
    else
      echo -e "Enter FIELD name to set: \c"
      read setField
      setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tName)
      if [[ $setFid == "" ]]
      then
        echo "Not Found"
      else
        echo -e "Enter new Value to set: \c"
        read newValue
        NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tName 2>>./.error.log)
        oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tName 2>>./.error.log)
        echo $oldValue
        sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tName 2>>./.error.log
        echo "Row Updated Successfully"
      fi
    fi
  fi
  printDBmenu
}

function selectCond() {
  echo -e "Enter required FIELD name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    selectCond
  else
    echo -e "\nSupported Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
    read op
    if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
    then
      echo -e "\nEnter required VALUE: \c"
      read val
      res=$(awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|')
      if [[ $res == "" ]]
      then
        echo "Value Not Found"
        selectCond
      else
        awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|'
        selectCond
      fi
    else
      echo "Unsupported Operator\n"
      selectCond
    fi
  fi
}
function selectMenu () {
  echo -e "Enter Table Name: \c"
  read tName
    if ! [[ -f $tName ]]; then
    echo "Table $tName doesn't exist!"
    selectMenu
  fi
  echo "1. Select All From a Table"
  echo "2. Select Specific Row from a Table"
  echo "3. Select Specific Column from a Table"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)   column -t -s '|' $tName 2>>./.error.log
  if [[ $? != 0 ]]
  then
    echo "Error Displaying Table $tName"
  fi
  selectMenu;;
    2) selectCond $tName ;;
    3)   echo -e "Enter Column Number: \c"
  read colNum
  awk 'BEGIN{FS="|"}{print $'$colNum'}' $tName ;;
    *) echo " Wrong Choice " ; selectMenu;
  esac
  printDBmenu
}


function connectDB(){
  echo -e "\nEnter the database name (or ! to return): \c"
  read dirname
      if [ "$dirname" = "!" ]; then
        menuOptions
        return
    fi
  if [ -d "$dirname" ]; then
    cd $dirname
    echo -e "\nConnected to #$dirname\n"
    printDBmenu
  else
    echo -e "\nNo such database exists.\n"
  fi
  connectDB
}

function menuOptions(){
  # Menu options
options=("Create Database" "List Database" "Drop Database" "Connect to Database" "Quit")

PS3="Please select a menu option: "
# Display the menu and read user input
select choice in "${options[@]}"; do
    case $choice in
        "Create Database")
            createDB
            ;;
        "List Database")
            echo -e "\nListing existing databases...\n"
            ls
            ;;
        "Drop Database")
            echo "Dropping a database..."
            removeDB
            ;;
        "Connect to Database")
            echo "Connecting to a database..." 
            connectDB
            ;;
        "Quit")
            echo "Exiting..."
            exit
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
done
}
# Create the "database" directory if it doesn't exist
if [ ! -d "databases" ]; then
    echo "Database directory does not exist. Creating..."
    mkdir "databases" || exit 1
fi

# Change to the "database" directory
cd "databases" || exit 1





menuOptions
