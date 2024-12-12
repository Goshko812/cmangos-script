# Setting Up Uptime Kuma Monitoring for a Server

1. **Log into Uptime Kuma**
   - Open your Uptime Kuma instance in a web browser.
   - Navigate to the dashboard.

2. **Add a New Monitor**
   - Click the `Add New Monitor` button in the top-right corner.

3. **Configure the Monitor**
   - In the "Monitor Type" dropdown, select `TCP Port`.
   - Fill in the following fields:
     - **Friendly Name**: Enter a descriptive name for your monitor (e.g., `World of Warcraft`).
     - **Hostname**: Input the server's IP address or domain name of the server (e.g., `75.148.167.110`).
     - **Port**: Specify the port to monitor (the default world server port is `8085` and the default authentication server port is `3724`).
     - **Heartbeat Interval**: Set how often Uptime Kuma should check the server (e.g., `60` seconds).
     - **Retries**: Set the number of retries before marking the server as down (e.g., `0`).
     - **Heartbeat Retry Interval**: Specify the interval for retrying (e.g., `60` seconds).
     - **Resend Notification**: Optionally, set how many times the notification should resend if the service remains down (e.g., `0`).

4. **Advanced Options (Optional)**
   - **Upside Down Mode**: Enable if you want to flip the status (i.e., consider the service down if it is reachable).
   - **Monitor Group**: Add this monitor to an existing group (if any).
   - **Description**: Optionally, add a description for additional context.
   - **Tags**: Add tags to organize and filter monitors.

5. **Set Notifications**
   - Under the "Notifications" section:
     - Enable or configure notification methods (e.g., Matrix Webhook, Mail-in-a-Box).

6. **Save the Monitor**
   - Click the `Save` button at the bottom of the screen.

Your monitor is now set up in Uptime Kuma. It will regularly check the specified server and port, notifying you if the server becomes unreachable.
