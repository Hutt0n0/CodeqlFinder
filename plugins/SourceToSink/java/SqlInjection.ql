/**
 * @name SQl注入一
 * @kind path-problem
 * 
 */
 import java
 import semmle.code.java.dataflow.FlowSources
 import semmle.code.java.security.QueryInjection
 import DataFlow::PathGraph
 import semmle.code.java.dataflow.ExternalFlow
 /**
  * A taint-tracking configuration for unvalidated user input that is used in SQL queries.
  */

  class SqlInjectionSink extends QueryInjectionSink {
    SqlInjectionSink() { 
        sinkNode(this, "sql") or
        exists(MethodAccess ma | 
        (
            ma.getMethod().getDeclaringType().getAnAncestor().hasQualifiedName("io.vertx.ext.jdbc", "JDBCClient") or
            ma.getMethod().getDeclaringType().getAnAncestor().hasQualifiedName("io.vertx.ext.sql", "SQLConnection")
        ) and 
            this.asExpr() = ma
        )

    
    }
}



 class QueryInjectionFlowConfig extends TaintTracking::Configuration {
   QueryInjectionFlowConfig() { this = "SqlInjectionMyProject.lib::QueryInjectionFlowConfig" }
 
   override predicate isSource(DataFlow::Node src) { src instanceof RemoteFlowSource }
 
   override predicate isSink(DataFlow::Node sink) { sink instanceof SqlInjectionSink }
 
   override predicate isSanitizer(DataFlow::Node node) {
     node.getType() instanceof PrimitiveType or
     node.getType() instanceof BoxedType or
     node.getType() instanceof NumberType
   }
 
   override predicate isAdditionalTaintStep(DataFlow::Node node1, DataFlow::Node node2) {
     any(AdditionalQueryInjectionTaintStep s).step(node1, node2)
        or
          //解决对象调用toString作为参数传入方法断层的问题，例如：Object TEST = "test"; dirty(TEST.toString);
          exists(MethodAccess ma |
            //判断被调用的方法的所属对象是否继承Object
        ma.getMethod().getDeclaringType() instanceof TypeObject and
        ma.getMethod().getName() = "toString" and
        ma.getQualifier() = node1.asExpr() and
        ma = node2.asExpr()
        ) 
        or 
  
        exists(Call call |
            node1.asExpr() = call.getAnArgument() and
            node2.asExpr() = call.getQualifier()
        )
        or 
  
        
        exists(Call call |
            node1.asExpr() = call.getQualifier() and
            node2.asExpr() = call
        )
  
        or 
  
        exists(Call call |
            node2.asExpr()=call and 
            call.getAnArgument()=node1.asExpr()
        )
   }
 }
 
 /**
  * Implementation of `SqlTainted.ql`. This is extracted to a QLL so that it
  * can be excluded from `SqlUnescaped.ql` to avoid overlapping results.
  */
 predicate queryTaintedBy(
   QueryInjectionSink query, DataFlow::PathNode source, DataFlow::PathNode sink
 ) {
   exists(QueryInjectionFlowConfig conf | conf.hasFlowPath(source, sink) and sink.getNode() = query)
 }
 

 from QueryInjectionFlowConfig qconfig,DataFlow::PathNode source, DataFlow::PathNode sink
 where qconfig.hasFlowPath(source, sink)
 select sink.getNode(), source, sink,"拼接导致的SQL注入"
