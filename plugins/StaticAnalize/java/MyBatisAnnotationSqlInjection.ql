

import java
import MyBatisCommonLib
import MyBatisAnnotationSqlInjectionLib
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import MyBatisAnnotationSqlInjectionFlow::PathGraph

private module MyBatisAnnotationSqlInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) { sink instanceof MyBatisAnnotatedMethodCallArgument }

  predicate isBarrier(DataFlow::Node node) {
    node.getType() instanceof PrimitiveType or
    node.getType() instanceof BoxedType or
    node.getType() instanceof NumberType
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(MethodAccess ma |
      ma.getMethod().getDeclaringType() instanceof TypeObject and
      ma.getMethod().getName() = "toString" and
      ma.getQualifier() = node1.asExpr() and
      ma = node2.asExpr()
    )
  }
}

private module MyBatisAnnotationSqlInjectionFlow =
  TaintTracking::Global<MyBatisAnnotationSqlInjectionConfig>;

from
  MyBatisAnnotationSqlInjectionFlow::PathNode source,
  MyBatisAnnotationSqlInjectionFlow::PathNode sink, IbatisSqlOperationAnnotation isoa,
  MethodAccess ma, string unsafeExpression
where
  ma.getAnArgument() = sink.getNode().asExpr() and
  myBatisSqlOperationAnnotationFromMethod(ma.getMethod(), isoa) and
  unsafeExpression = getAMybatisAnnotationSqlValue(isoa) and
  (
    isMybatisXmlOrAnnotationSqlInjection(sink.getNode(), ma, unsafeExpression) or
    isMybatisCollectionTypeSqlInjection(sink.getNode(), ma, unsafeExpression)
  )
select sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), isoa, "Mybatis Annotation SQL Injection"
