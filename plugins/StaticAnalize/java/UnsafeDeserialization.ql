import java
import semmle.code.java.security.UnsafeDeserializationQuery
import DataFlow::PathGraph

from DataFlow::PathNode sink
where sink.getNode() instanceof UnsafeDeserializationSink
select 
sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(),
  "Unsafe deserialization"