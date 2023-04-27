/**
 * @name 表达式注入
 * @kind path-problem
 * 
 */
import java
import semmle.code.java.security.MvelInjectionQuery
import semmle.code.java.security.JexlInjectionQuery
import semmle.code.java.security.GroovyInjectionQuery
import semmle.code.java.security.SpelInjectionQuery
import semmle.code.java.security.TemplateInjectionQuery
import semmle.code.java.security.XsltInjectionQuery
private import semmle.code.java.frameworks.spring.SpringExpression
private import semmle.code.java.security.SpelInjection


import DataFlow::PathGraph


from DataFlow::PathNode sink
where 
      sink.getNode() instanceof GroovyInjectionSink or
      sink.getNode() instanceof JexlEvaluationSink  or
      sink.getNode() instanceof MvelEvaluationSink or 
      sink.getNode() instanceof SpelExpressionEvaluationSink or
      exists(DataFlow::FlowState state|sink.getNode().(TemplateInjectionSink).hasState(state)) or
      sink.getNode() instanceof XsltInjectionSink
      
select sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "el script injection"