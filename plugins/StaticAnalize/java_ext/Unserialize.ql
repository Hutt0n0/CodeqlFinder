import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.DataFlow

class UnserializeSink extends DataFlow::Node {
    UnserializeSink(){
        exists(MethodAccess ma,Class c | ma.getMethod().hasName("readObject") and 
                ma.getQualifier().getType() = c and 
                c.getASupertype*().hasQualifiedName("java.io", "InputStream") and 
                this.asExpr() = ma
        )
    }
}

class UnserializeSanitizer extends DataFlow::Node { 
    UnserializeSanitizer() {
      this.getType() instanceof BoxedType or this.getType() instanceof PrimitiveType
    }
  }


  

from  DataFlow::PathNode sink
where sink.getNode() instanceof UnserializeSink 
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Potential JAVA Unserialize Vulnerability"
