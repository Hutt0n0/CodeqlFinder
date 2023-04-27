import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.ExternalFlow
import DataFlow::PathGraph

class FileWriteSink extends DataFlow::Node {
    FileWriteSink(){
        exists( ConstructorCall cc |
            cc.getConstructor().getName() = "FileOutputStream" and
            cc.getArgument(0) = this.asExpr()
        )
    }
}

from  DataFlow::PathNode sink
where
  sink.getNode() instanceof FileWriteSink 
select sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Possiable arbitrarily File Write Vulnerablity"