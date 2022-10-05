# Shopify Mutlipass Token Demo

Demo showing how to create a Shopify Multipass token, and subsequent redirect url.

## Dependencies

- crypto
- encrypt


## Important Note About Customer Payload

The most frustrating part of this research was working through the customer `identifier` field. If the customer record in Shopify was created with the `identifier` field, be sure to include it in the token request.
If you didn't create the customer with an `identifier` field, it defaults to null, but you STILL have to include it in the customer payload when creating the token request. Be sure to set it to `null`. An empty string will not work.

## Author: Jade Charles - 2022
