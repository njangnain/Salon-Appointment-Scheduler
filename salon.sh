#!/bin/bash

# Connect to PostgreSQL using the freeCodeCamp user
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "\n~~~~~ Welcome to the Salon ~~~~~\n"
  echo -e "Here are the services we offer:\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Main program logic
MAIN_MENU() {
  DISPLAY_SERVICES

  # Prompt user to pick a service
  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # If service doesn't exist, show services again
  while [[ -z $SERVICE_NAME ]]
  do
    echo -e "\nThat is not a valid service."
    DISPLAY_SERVICES
    echo -e "\nPlease select a service by entering the service_id:"
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  done

  # Continue with booking the appointment
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if the customer already exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    # If customer doesn't exist, get their name
    echo -e "\nIt looks like you're a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert the new customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Prompt for appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert the appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm the appointment
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Run the main menu function
MAIN_MENU
