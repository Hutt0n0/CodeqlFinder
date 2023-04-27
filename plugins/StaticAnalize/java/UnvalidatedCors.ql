import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.frameworks.Servlets
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.TaintTracking2
import DataFlow::PathGraph


/**
 *  Holds if `header` sets `Access-Control-Allow-Credentials` to `true`. This ensures fair chances of exploitability.
 */
private predicate setsAllowCredentials(MethodAccess header) {
  (
    header.getMethod() instanceof ResponseSetHeaderMethod or
    header.getMethod() instanceof ResponseAddHeaderMethod
  ) and
  header.getArgument(0).(CompileTimeConstantExpr).getStringValue().toLowerCase() =
    "access-control-allow-credentials" and
  header.getArgument(1).(CompileTimeConstantExpr).getStringValue().toLowerCase() = "true"
}

private class CorsProbableCheckAccess extends MethodAccess {
  CorsProbableCheckAccess() {
    getMethod().hasName("contains") and
    getMethod().getDeclaringType().getASourceSupertype*() instanceof CollectionType
    or
    getMethod().hasName("containsKey") and
    getMethod().getDeclaringType().getASourceSupertype*() instanceof MapType
    or
    getMethod().hasName("equals") and
    getQualifier().getType() instanceof TypeString
  }
}

private Expr getAccessControlAllowOriginHeaderName() {
  result.(CompileTimeConstantExpr).getStringValue().toLowerCase() = "access-control-allow-origin"
}




from
  DataFlow::PathNode source, DataFlow::PathNode sink
where     
exists(MethodAccess corsHeader, MethodAccess allowCredentialsHeader |
  (
    corsHeader.getMethod() instanceof ResponseSetHeaderMethod or
    corsHeader.getMethod() instanceof ResponseAddHeaderMethod
  ) and
  getAccessControlAllowOriginHeaderName() = corsHeader.getArgument(0) and
  setsAllowCredentials(allowCredentialsHeader) and
  corsHeader.getEnclosingCallable() = allowCredentialsHeader.getEnclosingCallable() and
  sink.getNode().asExpr() = corsHeader.getArgument(1)
)
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(),  "CORS header is being set using user controlled value "
