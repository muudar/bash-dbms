#!/bin/bash


function createDB {
  echo -e "\nCreating a new database...\n"
  echo -e "Enter Database Name: \c"
  read dbName
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

PS3="Please select an option (enter the number): "

# Display the menu and read user input
select choice in "${options[@]}"; do
    case $choice in
        "Create Database")
            createDB
            ;;
        "List Database")
<<<<<<< HEAD
            echo "Listing existing databases..."
=======
            echo "Listing existing databases..."
>>>>>>> a49f551c4762e4c15c30e8a51a256089788e59d5
            # Add your code for listing databases here
            ;;
        "Drop Database")
            echo "Dropping a database..."
            # Add your code for dropping a database here
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
done


