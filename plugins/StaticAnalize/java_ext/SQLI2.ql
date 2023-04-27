import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.ExternalFlow
import DataFlow::PathGraph

class SQLISink extends DataFlow::Node {
    SQLISink(){
        exists(MethodAccess ma,RefType t |
            (
              (
                  ma.getMethod().getName() = "prepareStatement" and
                  ma.getQualifier().getType().getTypeDescriptor() = "Ljava/sql/Connection;"
              ) or
              (
                (
                  ma.getMethod().getName() = "executeQuery" or
                  ma.getMethod().getName() = "execute"
                )
                and
                (
                  ma.getQualifier().getType().getTypeDescriptor() = "Ljava/sql/Statement;" or
                  ma.getQualifier().getType().getTypeDescriptor() = "Ljava/sql/PreparedStatement;" 
                )
              ) or
              (
                (
                  ma.getMethod().hasName("createSQLQuery") or
                  ma.getMethod().hasName("createQuery")
                ) and
                ma.getQualifier().getType() = t and
                (
                    t.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("org.hibernate", "Session") or
                    t.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("org.hibernate", "StatelessSession")
                )
              ) or
              (
                ma.getMethod().hasName("query") and
                ma.getQualifier().getType() = t and
                t.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("org.apache.commons.dbutils", "QueryRunner") 
              )
            ) and
            this.asExpr() = ma.getArgument(0)
        )
    }
}

class SQLIConfig extends TaintTracking::Configuration {
    SQLIConfig() { this = "SQLI Vulnerability" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof SQLISink }

}

from DataFlow::PathNode sink
where
  sink.getNode() instanceof SQLISink
select 
      sink,sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Potential SQLI Vulnerability"
