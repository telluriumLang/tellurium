# Syntax Reference

## Variable declaration
    
```Tellurium
let <NAME>=<VALUE>
```
    
## Variable assignment
    
```Tellurium
<NAME>=<VALUE>
```

## Find element
    
```Tellurium
$("<SELECTOR>")
```

## Find elements
    
```Tellurium
$["<SELECTOR>"]
```

## Extract element from list
    
```Tellurium
<ELEMENT_LIST>[<INDEX>]
```

## Get information
    
```Tellurium
get <GET_INFO_ACTION> from [<TARGET>] [window]
```
    
## Get attribute
    
```Tellurium
get attribute <KEY> from <TARGET>
```

## Driver configuration statement
    
```Tellurium
using <DRIVER_TYPE> driver
```
    
## Driver implicitly wait statement
    
```Tellurium
driver implicitly wait <SEC> s
```
    
## Test case
    
```Tellurium
test <NAME>{
    <TEST_STATEMENT>...
}
```

## Open page statement
    
```Tellurium
open <URL>
```

## Navigate statement
    
```Tellurium
navigate {back|forward|refresh}
```

## Window
    
```Tellurium
window {maximize|fullscreen}
```

## Quit and close
    
```Tellurium
quit
```

## Keyboard input
    
```Tellurium
enter [<MODIFIER> +] <STRING> [into <TARGET>]
```

## Mouse input

```Tellurium
mouse {click|doubleClick|clickAndHold|rightClick|release} on <TARGET>
mouse move [to <TARGET>] [by <OFFSET>]
mouse drag and drop from <SOURCE> {to <TARGET>|by <OFFSET>}
```

## Cookie add and delete
    
```Tellurium
cookie add <KEY> with value <VALUE>
```
    
## Assertion

```Tellurium
assert <ACTUAL> is {true|false} [with message <MESSAGE>]
assert <ACTUAL> {is|not} null [with message <MESSAGE>]
assert <ACTUAL> {==|!=} <EXPECTED> [with message <MESSAGE>]
assert <NEEDLE> [not] in <HAYSTACK> [with message <MESSAGE>]
```