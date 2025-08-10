# Developer Notes

The structure of basic objects. 

```mermaid
classDiagram
    Param <|-- ShareVars
    Param <|-- SitePar
    Param <|-- VegPar
    
    class Param{
        +initialize()
    }
    class ShareVars{
        +glb: global variable list
        +vars: variable list
        +logdt: variable logs at each time
        +initialize()
        +logvars()
        +output_pnet_ii()
        +output_pnet_day()
        +output_pnet_cn()
    }
    class SitePar{
        +Lat
        +WHC
        ...
    }
    class VegPar{
        +FolNCon
        +FolMassMax
        ...
    }
```

For each process (e.g., phenology, photosynthesis) function, we update all variable values at the end of the function so that it is clear which variables are updated by the function.

For quick reference, [here's a summary of equations used in the model](../doc/PnET-CN%20equations.svg), which can be downloaded for better visualization.

![](../doc/PnET-CN%20equations.svg)

