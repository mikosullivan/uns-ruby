# Declutter

Declutters your Ruby hashes and arrays by removing empty arrays and hashes.
Also has options for removing nils, redundancies and falses, and objects that
respond to `#declutter`.

In this simple example, we create a hash structure that contains an empty array:

```ruby
#!/usr/bin/ruby -w
require 'declutter'

myhash = { 'title' => 'Titus Andronicus', 'episodes' => [] }
puts myhash # => {"title"=>"Titus Andronicus", "episodes"=>[]}
Declutter.process myhash
puts myhash # => {"title"=>"Titus Andronicus"}
```

By running the hash through `Declutter.process`, we remove the empty array. If
an array contains only an empty array, then the whole array structure is
removed:

```ruby
myhash = { 'title' => 'Titus Andronicus', 'episodes' => ['scenes'=>[]] };
puts myhash # => {"title"=>"Titus Andronicus", "episodes"=>[{"scenes"=>[]}]}
Declutter.process myhash
puts myhash # => {"title"=>"Titus Andronicus"}
```

The same concept goes for empty hashes:

```ruby
myhash = {'title' => 'Titus Andronicus', 'notes' => {'ideas'=>{}} }
puts myhash # => {"title"=>"Titus Andronicus", "notes"=>{}}
Declutter.process myhash
puts myhash # => {"title"=>"Titus Andronicus"}
```

## Object oriented approach

To refine what elements are deleted, instantiate `Declutter` to set what type of
elements are deleted.

### nil

To delete nils, set `declutter.delete_nils` to true:

```ruby
myhash = { 'episodes'=>['pilot', nil, 'transition'] }
puts myhash # => {"episodes"=>["pilot", nil, "transition"]}

declutter = Declutter.new()
declutter.delete_nils = true
declutter.process myhash

puts myhash # => {"episodes"=>["pilot", "transition"]}
```

If deleting the nil values results in an empty array, then the array is deleted.

```ruby
myhash = { 'episodes'=>[nil] }
puts myhash # => { 'episodes'=>[nil] }

declutter = Declutter.new()
declutter.delete_nils = true
declutter.process myhash

puts myhash # => {}
```

### redundancies

To delete redundant elements in arrays, set `declutter.delete_redundancies` to
true.

```ruby
myhash = { 'episodes'=>['pilot', 'pilot'] }
puts myhash # => { 'episodes'=>['pilot', 'pilot'] }

declutter = Declutter.new()
declutter.delete_redundancies = true
declutter.process myhash

puts myhash # => { 'episodes'=>['pilot'] }
```

### false

To delete false values, set `declutter.delete_falses` to true:

```ruby
myhash = { 'episodes'=>['pilot', false] }
puts myhash # => {"episodes"=>["pilot", false]}

declutter = Declutter.new()
declutter.delete_falses = true
declutter.process myhash

puts myhash # => {"episodes"=>["pilot"]}
```

### keep empty hashes and/or arrays

To keep empty hashes, set `declutter.delete_empty_hashes` to false:

```ruby
myhash = { 'episodes'=>[], 'notes'=>{} }
puts myhash # => {"episodes"=>[], "notes"=>{}}

declutter = Declutter.new()
declutter.delete_empty_hashes = false
declutter.process myhash

puts myhash # => {"notes"=>{}}
```

To keep empty arrays, set `declutter.delete_empty_arrays` to false:

```ruby
myhash = { 'episodes'=>[], 'notes'=>{} }
puts myhash # => {"episodes"=>[], "notes"=>{}}

declutter = Declutter.new()
declutter.delete_empty_arrays = false
declutter.process myhash

puts myhash # => {"episodes"=>[]}
```

### objects of other classes

Objects of your own custom class can be decluttered if they have a `#declutter`
method. Consider these two classes.

```ruby
class KeepMe
   def declutter
      return true
   end
end

class DeleteMe
   def declutter
      return false
   end
end
```

Both classes have declutter methods. `KeepMe#declutter` returns true and
`DeleteMe#declutter` returns false. In this first example, we use the default
settings to declutter the hash.

```ruby
hsh = {}
hsh['keep-it'] = KeepMe.new
hsh['delete-it'] = DeleteMe.new

Declutter.process hsh

puts hsh # => {"keep-it"=>#<KeepMe:0x0000559f8574b718>}
```

The `keep-it` element was kept because `KeepMe#declutter` returns true. However,
the `delete-it` element was deleted because `DeleteMe#declutter` returns false.

To bypass decluttering objects that have a `#declutter` method, use the object
oriented approach and set `process_others` to false:

```ruby
hsh = {}
hsh['keep-it'] = KeepMe.new
hsh['delete-it'] = DeleteMe.new

declutter = Declutter.new
declutter.process_others = false
declutter.process hsh

puts hsh # => {"keep-it"=>#<KeepMe:0x000055e5ffd46f80>, "delete-it"=>#<DeleteMe:0x000055e5ffd46f30>}
```

## History

| date         | version | notes           |
|--------------|---------|-----------------|
| May 23, 2023 | 1.0     | Initial upload. |
| May 29, 2023 | 1.1     | Added ability to call #declutter on any object that responds to that method. |
| June 9, 2023 | 1.2     | Changed tests to Minitest. No change to functionality. |