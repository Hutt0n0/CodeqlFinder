import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.DataFlow

class XStreamSink extends DataFlow::Node {
  XStreamSink(){
        exists(MethodAccess ma,Class c | ma.getMethod().hasName("fromXML") and 
                ma.getQualifier().getType() = c and 
                c.hasQualifiedName("com.thoughtworks.xstream", "XStream") and 
                ma.getArgument(0) = this.asExpr()
        )
    }
}



from DataFlow::PathNode sink
where
  sink.getNode() instanceof XStreamSink
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Potential XStream Unserialize Vulnerability"
