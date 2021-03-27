% mn Language Developer Guide
% Fabio Cevasco
% -

<style>
.reference-title {
  font-size: 120%;  
  font-weight: 600;
}
.min-terminal {
    -moz-background-clip: padding;
    -webkit-background-clip: padding-box;
    background-clip: padding-box;
    -webkit-border-radius: 3px;
    -moz-border-radius: 3px;
    border-radius: 3px;
    margin: 10px auto;
    padding: 2px 4px 0 4px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.8);
    color: #eee;
    background-color: #222;
    border: 1px solid #ccc;
    white-space: pre;
    padding: 0 3px;
    border: 2px solid #999;
    border-top: 10px solid #999;
}
.min-terminal p {
  margin: 0 auto;  
}
.min-terminal p, .min-terminal p:first-child {
    margin-top: 0;
    margin-bottom: 0;
    text-shadow: none;
    font-weight: normal;
    font-family: "Source Code Pro", "Monaco", "DejaVu Sans Mono", "Courier New", monospace;
    font-size: 85%;
    color: #eee;
}
</style>

## About min

{@ docs/about.md || 1 @}

## Get Started

{@ docs/get-started.md || 1 @}

## Learning the min Language

{@ docs/learn.md || 1 @}

### Data Types

{@ docs/learn-data-types.md || 2 @}

### Quotations

{@ docs/learn-quotations.md || 2 @}

### Operators 

{@ docs/learn-operators.md || 2 @}

### Definitions

{@ docs/learn-definitions.md || 2 @}

### Scopes

{@ docs/learn-scopes.md || 2 @}

### Control Flow

{@ docs/learn-control-flow.md || 2 @}

## Extending mn

{@ docs/learn-extending.md || 1 @}

## Reference

{@ docs/reference.md || 1 @}


### `lang` Module

{@ docs/reference-lang.md || 1 @}

### `stack` Module

{@ docs/reference-stack.md || 1 @}

### `seq` Module

{@ docs/reference-seq.md || 1 @}

### `io` Module

{@ docs/reference-io.md || 1 @}

### `logic` Module

{@ docs/reference-logic.md || 1 @}

### `str` Module

{@ docs/reference-str.md || 1 @}

### `sys` Module

{@ docs/reference-sys.md || 1 @}

### `num` Module

{@ docs/reference-num.md || 1 @}

### `time` Module

{@ docs/reference-time.md || 1 @}

### `math` Module

{@ docs/reference-math.md || 1 @}


{#op => 
<a id="min-operator-id-$1"></a>
[$1](class:reference-title)

> %operator%
> [ $2 **&rArr;** $3](class:kwd)
> 
> $4
 #}


{#alias => 
[$1](class:reference-title)

> %operator%
> [ $1 **&rArr;** $2](class:kwd)
> 
> See [$2](#min-operator-id-$2).
 #}

{#sig => 
[$1](class:reference-title) [](class:sigil)

> %operator%
> [ $1{{s}} **&rArr;** {{s}} $2](class:kwd)
> 
> See [$2](#min-operator-id-$2).
 #}

{# link-page => $2 #}

{# link-module => [$1 Module](#<code>$1</code>-Module) #}

{# link-operator => [$2](#min-operator-id-$2) #}

{# link-learn => #}

{{learn-links =>   }}

{{guide-download =>   }}
