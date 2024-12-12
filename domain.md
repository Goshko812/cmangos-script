# Configuring a Custom Realm List for CMaNGOS WoW

To use a custom realm list for your CMaNGOS WoW setup, you'll need to configure a DNS record or edit your hosts file to point to the IP address of your server. This guide will walk you through the process of setting up a custom realm list using `wow.example.com` as an example.

## Option 1: Using a DNS Service
------------------------------

Using a DNS service is the recommended method for setting up a custom realm list. Here's how to do it:

* Create a DNS record for your domain `wow.example.xyz` that points to your public IP.
* You can use a DNS service like Cloudflare, Google Domains, or Namecheap.

## Option 2: Editing Your Hosts File
----------------------------------

Editing your hosts file is not recommended for production use, but it can be a useful testing method. Here's how to do it:

### Step 1: Open the Hosts File
* On Linux/Mac: `/etc/hosts`

### Step 2: Add the DNS Record
* Add the following line to the end of the file: `<your-public-ip> wow.example.xyz`
* Save the changes.

## Testing Your Configuration
---------------------------

### Step 1: Update Your WoW Client

* Update your WoW client's `realmlist.wtf` file to point to `wow.bidonov.xyz`.

### Step 2: Launch WoW

* Launch WoW and try connecting to your server.

If everything is set up correctly, you should be able to connect to your server using the `wow.example.xyz` realm list.

**Note**: If you're using a DNS service, make sure to update the DNS record if your IP address changes. If you're using the hosts file method, you'll need to update the hosts file on every system that needs to connect to your server.
