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

}
function printDBmenu() {
    echo -e "\nSelect an option:"
    echo -e "\n1. Create table"
    echo -e "\n2. Drop table"
    echo -e "\n3. Insert into table"
    echo -e "\n4. Select from table"
    echo -e "\n5. Delete from table"
    echo -e "\n6. Update table"
    echo -e "\n7. Back\n"
    read -p "Enter your choice: " choice
        case $choice in
        1)  createTable;;
        2)  echo "Drop Table";;
        3)  echo "Insert into table";;
        4)  echo "Select from table";;
        5)  echo "Delete from table";;
        6)  echo "Update table";;
        7)  cd .. 
        menuOptions ;;
        *) echo "Invalid option. Please try again." 
        printDBmenu ;;
    esac
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

