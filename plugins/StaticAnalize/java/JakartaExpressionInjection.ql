import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph


/**
 * Holds if `fromNode` to `toNode` is a dataflow step that returns data from
 * a bean by calling one of its getters.
 */
predicate hasGetterFlow(DataFlow::Node fromNode, DataFlow::Node toNode) {
  exists(MethodAccess ma, Method m | ma.getMethod() = m |
    m instanceof GetterMethod and
    ma.getQualifier() = fromNode.asExpr() and
    ma = toNode.asExpr()
  )
}


/**
 * A sink for Expresssion Language injection vulnerabilities,
 * i.e. method calls that run evaluation of an expression.
 */
private class ExpressionEvaluationSink extends DataFlow::ExprNode {
  ExpressionEvaluationSink() {
    exists(MethodAccess ma, Method m, Expr taintFrom |
      ma.getMethod() = m and taintFrom = this.asExpr()
    |
      m.getDeclaringType() instanceof ValueExpression and
      m.hasName(["getValue", "setValue"]) and
      ma.getQualifier() = taintFrom
      or
      m.getDeclaringType() instanceof MethodExpression and
      m.hasName("invoke") and
      ma.getQualifier() = taintFrom
      or
      m.getDeclaringType() instanceof LambdaExpression and
      m.hasName("invoke") and
      ma.getQualifier() = taintFrom
      or
      m.getDeclaringType() instanceof ELProcessor and
      m.hasName(["eval", "getValue", "setValue"]) and
      ma.getArgument(0) = taintFrom
      or
      m.getDeclaringType() instanceof ELProcessor and
      m.hasName("setVariable") and
      ma.getArgument(1) = taintFrom
    )
  }
}

/**
 * Defines method calls that propagate tainted expressions.
 */
private class TaintPropagatingCall extends Call {
  Expr taintFromExpr;

  TaintPropagatingCall() {
    taintFromExpr = this.getArgument(1) and
    (
      exists(Method m | this.(MethodAccess).getMethod() = m |
        m.getDeclaringType() instanceof ExpressionFactory and
        m.hasName(["createValueExpression", "createMethodExpression"]) and
        taintFromExpr.getType() instanceof TypeString
      )
      or
      exists(Constructor c | this.(ConstructorCall).getConstructor() = c |
        c.getDeclaringType() instanceof LambdaExpression and
        taintFromExpr.getType() instanceof ValueExpression
      )
    )
  }

  /**
   * Holds if `fromNode` to `toNode` is a dataflow step that propagates
   * tainted data.
   */
  predicate taintFlow(DataFlow::Node fromNode, DataFlow::Node toNode) {
    fromNode.asExpr() = taintFromExpr and toNode.asExpr() = this
  }
}

private class JakartaType extends RefType {
  JakartaType() { this.getPackage().hasName(["javax.el", "jakarta.el"]) }
}

private class ELProcessor extends JakartaType {
  ELProcessor() { this.hasName("ELProcessor") }
}

private class ExpressionFactory extends JakartaType {
  ExpressionFactory() { this.hasName("ExpressionFactory") }
}

private class ValueExpression extends JakartaType {
  ValueExpression() { this.hasName("ValueExpression") }
}

private class MethodExpression extends JakartaType {
  MethodExpression() { this.hasName("MethodExpression") }
}

private class LambdaExpression extends JakartaType {
  LambdaExpression() { this.hasName("LambdaExpression") }
}



from DataFlow::PathNode sink
where sink.getNode() instanceof ExpressionEvaluationSink
select 
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "Jakarta Expression Language injection"
