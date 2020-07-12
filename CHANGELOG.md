# Changelog

## Unreleased (2.0)

- Updated all dependencies
- More robust error handling
- Extract all user attributes

### Upgrading from previous version

There are some small incompatibilities in version 2.

- There are now more error keys. For example, following responses:

  ```xml
  <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
    <cas:authenticationFailure code="INVALID_TICKET">Ticket 'ST-XXXXX' already consumed</cas:authenticationFailure>
  </cas:serviceResponse>
  ```
  
  used to result in `{"error", "INVALID_TICKET"}`.
  This will now result in `{"INVALID_TICKET", "Ticket 'ST-XXXXX' already consumed"}`.
  Similarly, there is now a separate error code for malformed XML responses.
  You should in general no rely on the error message keys being constant.
  
- The raw user struct has changed. The fields `email` and `roles` have been removed.
  They can now be found in the new `attributes` field, which is a map of all attributes.

- The `email` no longer defaults to the username, but a `cas:email` attribute. You can configure which attribute is used, see the docs.
