import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.DataFlow

class FastjsonSink extends DataFlow::Node {
    FastjsonSink(){
        exists(MethodAccess ma,Class c | ma.getMethod().hasName("parseObject") and 
                ma.getQualifier().getType() = c and 
                c.hasQualifiedName("com.alibaba.fastjson", "JSON") and 
                ma.getArgument(0) = this.asExpr() and 
                ma.getNumArgument() = 1
        )
    }
}



from  DataFlow::PathNode sink
where
  sink.getNode() instanceof FastjsonSink
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Potential Fastjson Unserialize Vulnerability"
