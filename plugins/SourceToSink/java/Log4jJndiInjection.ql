import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.ExternalFlow
import DataFlow::PathGraph





/** A data flow sink for unvalidated user input that is used to log messages. */
class Log4jInjectionSink extends DataFlow::Node {
  Log4jInjectionSink() { sinkNode(this, "log4j") }
}

/**
 * A node that sanitizes a message before logging to avoid log injection.
 */
class Log4jInjectionSanitizer extends DataFlow::Node {
  Log4jInjectionSanitizer() {
    this.getType() instanceof BoxedType or this.getType() instanceof PrimitiveType
  }
}

/**
 * A taint-tracking configuration for tracking untrusted user input used in log entries.
 */
class Log4jInjectionConfiguration extends TaintTracking::Configuration {
  Log4jInjectionConfiguration() { this = "Log4jInjectionConfiguration" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof Log4jInjectionSink }

  override predicate isSanitizer(DataFlow::Node node) { node instanceof Log4jInjectionSanitizer }
}

from Log4jInjectionConfiguration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select source.toString(),source.getNode().getEnclosingCallable(),source.getNode().getEnclosingCallable().getFile().getAbsolutePath(), 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Log4j log"
