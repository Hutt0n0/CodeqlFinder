

import java
import MyBatisCommonLib
import MyBatisMapperXmlSqlInjectionLib
import semmle.code.xml.MyBatisMapperXML
import semmle.code.java.dataflow.FlowSources
import MyBatisMapperXmlSqlInjectionFlow::PathGraph

private module MyBatisMapperXmlSqlInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) { sink instanceof MyBatisMapperMethodCallAnArgument }

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

private module MyBatisMapperXmlSqlInjectionFlow =
  TaintTracking::Global<MyBatisMapperXmlSqlInjectionConfig>;

from
  MyBatisMapperXmlSqlInjectionFlow::PathNode source,
  MyBatisMapperXmlSqlInjectionFlow::PathNode sink, MyBatisMapperXmlElement mmxe, MethodAccess ma,
  string unsafeExpression
where
  
  ma.getAnArgument() = sink.getNode().asExpr() and
  myBatisMapperXmlElementFromMethod(ma.getMethod(), mmxe) and
  unsafeExpression = getAMybatisXmlSetValue(mmxe) and
  (
    isMybatisXmlOrAnnotationSqlInjection(sink.getNode(), ma, unsafeExpression)
    or
    mmxe instanceof MyBatisMapperForeach and
    isMybatisCollectionTypeSqlInjection(sink.getNode(), ma, unsafeExpression)
  )
select sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), mmxe, "MyBatis Mapper XML SQL injection"
