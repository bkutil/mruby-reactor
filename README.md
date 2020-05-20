# Reactor

Pure Ruby reactor implementation, with IO.select based demultiplexer.

## Dependencies

- mruby-io

## Usage

The reactor has three components: a Dispatcher, Demuxer, and Handlers.

### Dispatcher

Dispatcher holds a hash table associating:

- handles (IO objects, files, sockets)
- events that happen on these handles, or that are user defined, represented by a symbol
- handlers, callbacks to the events.

### Demuxer

Demuxer keeps two lists of handles (IO objects), for reads and writes. It then runs `IO#select` and on read or write event, notifies the dispatcher to run a callback for this event and handle.

### Handlers

A handler can be a Proc, or any object responding to a `#call` method. This method takes three arguments: `dispatcher` (self), `event` (Symbol), and the `handle` (IO),

## Example

```
read_handler = Proc.new do |reactor, handle, event|
  puts "Input #{handle.readline}"
end

dispatcher = Reactor::Dispatcher.new
dispatcher.register($stdin, :read, read_handler)
dispatcher.run
```

## Contributing

Patches/comments/bug reports/suggestions welcome.

## LICENSE

Released under [MIT](https://opensource.org/licenses/MIT) license.
