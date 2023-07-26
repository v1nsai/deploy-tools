#!/bin/bash

# Check if any users are currently logged in
users_logged_in=$(who | wc -l)

if [ "$users_logged_in" -eq 0 ]; then
  # No users are logged in, initiate system shutdown
  echo "No users logged in. Shutting down the system..."
  sudo shutdown now
else
  # Users are logged in, do nothing
  echo "Users are currently logged in. The system will not be shut down."
fi
