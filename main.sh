#!/bin/bash

function printMenu {
    echo -e "\n1-Create Database\n\n2-List Database\n\n3-Drop Database\n\n4-Connect to Database\n\n5-Quit\n"
}

function createDB {
  echo -e "\nCreating a new database...\n"
  echo -e "\nEnter '!' to return.\n"
  echo -e "Enter Database Name: \c"
  read dbName
      if [ "$dbName" = "!" ]; then
        printMenu
        return
    fi
      if [[ ! $dbName =~ ^[a-zA-Z0-9_-]+$ ]]; then
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
  printMenu
}

function removeDB() {
  echo -e "\nEnter the database file name (or ! to return): \c"
  read dirname
      if [ "$dirname" = "!" ]; then
        printMenu
        return
    fi
  ls
  if [ -d "$dirname" ]; then
    rm -r "$dirname"
    echo -e "\nDatabase file '$dirname' has been removed.\n"
    printMenu
    return
  else
    echo -e "\nNo such database exists.\n"
  fi
  removeDB
}



# Create the "database" directory if it doesn't exist
if [ ! -d "databases" ]; then
    echo "Database directory does not exist. Creating..."
    mkdir "databases" || exit 1
fi

# Change to the "database" directory
cd "databases" || exit 1


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
            # Add your code for connecting to a database here
            ;;
        "Quit")
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
            echo "bo2la"
done


