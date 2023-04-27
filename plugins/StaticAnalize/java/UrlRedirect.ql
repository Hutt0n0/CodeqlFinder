import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.security.UrlRedirect
import DataFlow::PathGraph

class UrlRedirectConfig extends TaintTracking::Configuration {
  UrlRedirectConfig() { this = "UrlRedirectConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof UrlRedirectSink }
}

from DataFlow::PathNode sink
where sink.getNode() instanceof UrlRedirectSink
select  sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(),"Untrusted URL redirection"