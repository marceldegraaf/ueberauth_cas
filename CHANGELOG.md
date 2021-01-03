# Changelog

## Version 2.1.0

- [Feature] Allow configuration of validation path (thanks to [Yann VERY](https://github.com/yannvery))
- [Feature] Allow dynamic configuration. This allows dynamically injecting CAS strategies, see PR#11. (thanks to [Yann VERY](https://github.com/yannvery))
- [Fix] Fix when `:sweet_xml` was not in the `applications`. The library now relies on Elixir to automatically populate the `applications`.
- [Other] Test against Elixir 1.11

## Version 2.0.1

- [Fix] Propagate network errors to Überauth instead of crashing.

## Version 2.0.0

- Updated all dependencies.
- More robust error handling. A proper XML parser is now used.
  Additionally, both the error code and error message are now passed to Überauth (see below).
- Extract all user attributes. The `email` and `roles` fields are replaced by a field `attributes`.
  This field contains all attributes from the response.
- More fields are extracted into the Überauth Info struct. By default, the strategy will insert
  attributes with the same name (e.g. `cas:location` will be inserted into `location`).
  This is configurable (see docs).

### Upgrading from previous versions

There are some small incompatibilities in version 2.

- There are now more error keys. For example, following response:

  ```xml
  <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
    <cas:authenticationFailure code="INVALID_TICKET">Ticket 'ST-XXXXX' already consumed</cas:authenticationFailure>
  </cas:serviceResponse>
  ```
  
  used to result in `{"error", "INVALID_TICKET"}`.
  This will now result in `{"INVALID_TICKET", "Ticket 'ST-XXXXX' already consumed"}`.
  Similarly, there is now a separate error code for malformed XML responses.
  You should be prepared to handle unknown error keys, since they come from the server.
  
- The raw user struct has changed. The fields `email` and `roles` have been removed.
  They can now be found in the new `attributes` field, which is a map of all attributes.

- The `email` no longer defaults to the username, but a `cas:email` attribute. You can configure which attribute is used, see the docs.

- The `roles` field was removed. This didn't actually do anything in the previous version, as it was always the same
  value.
  
Note that while not supported in the previous version, parsing attributes as json or yaml is still not supported.
Since this doesn't appear to be in the spec, it probably won't be supported. You can always read the field from
the attributes and parse it yourself.