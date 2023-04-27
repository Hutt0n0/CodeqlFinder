/**
 * @name JWT
 * @kind path-problem
 * 
 */
import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

private import semmle.code.java.dataflow.ExternalFlow
private import semmle.code.java.dataflow.FlowSources

/** The class `com.auth0.jwt.JWT`. */
class Jwt extends RefType {
  Jwt() { this.hasQualifiedName("com.auth0.jwt", "JWT") }
}

/** The class `com.auth0.jwt.JWTCreator.Builder`. */
class JwtBuilder extends RefType {
  JwtBuilder() { this.hasQualifiedName("com.auth0.jwt", "JWTCreator$Builder") }
}

/** The class `com.auth0.jwt.algorithms.Algorithm`. */
class JwtAlgorithm extends RefType {
  JwtAlgorithm() { this.hasQualifiedName("com.auth0.jwt.algorithms", "Algorithm") }
}

/**
 * The interface `com.auth0.jwt.interfaces.JWTVerifier` or its implementation
 * `com.auth0.jwt.JWTVerifier`.
 */
class JwtVerifier extends RefType {
  JwtVerifier() {
    this.hasQualifiedName(["com.auth0.jwt", "com.auth0.jwt.interfaces"], "JWTVerifier")
  }
}

/** A method that creates an instance of `com.auth0.jwt.algorithms.Algorithm`. */
class GetAlgorithmMethod extends Method {
  GetAlgorithmMethod() {
    this.getDeclaringType() instanceof JwtAlgorithm and
    this.getName().matches(["HMAC%", "ECDSA%", "RSA%"])
  }
}

/** The `require` method of `com.auth0.jwt.JWT`. */
class RequireMethod extends Method {
  RequireMethod() {
    this.getDeclaringType() instanceof Jwt and
    this.hasName("require")
  }
}

/** The `sign` method of `com.auth0.jwt.JWTCreator.Builder`. */
class SignTokenMethod extends Method {
  SignTokenMethod() {
    this.getDeclaringType() instanceof JwtBuilder and
    this.hasName("sign")
  }
}

/** The `verify` method of `com.auth0.jwt.interfaces.JWTVerifier`. */
class VerifyTokenMethod extends Method {
  VerifyTokenMethod() {
    this.getDeclaringType() instanceof JwtVerifier and
    this.hasName("verify")
  }
}

/**
 * A data flow source for JWT token signing vulnerabilities.
 */
abstract class JwtKeySource extends DataFlow::Node { }

/**
 * A data flow sink for JWT token signing vulnerabilities.
 */
abstract class JwtTokenSink extends DataFlow::Node { }

/**
 * A hardcoded string literal as a source for JWT token signing vulnerabilities.
 */
class HardcodedKeyStringSource extends JwtKeySource {
  HardcodedKeyStringSource() { exists(this.asExpr().(CompileTimeConstantExpr).getStringValue()) }
}

/**
 * An expression used to sign JWT tokens as a sink of JWT token signing vulnerabilities.
 */
private class SignTokenSink extends JwtTokenSink {
  SignTokenSink() {
    exists(MethodAccess ma |
      ma.getMethod() instanceof SignTokenMethod and
      this.asExpr() = ma.getArgument(0)
    )
  }
}

/**
 * An expression used to verify JWT tokens as a sink of JWT token signing vulnerabilities.
 */
private class VerifyTokenSink extends JwtTokenSink {
  VerifyTokenSink() {
    exists(MethodAccess ma |
      ma.getMethod() instanceof VerifyTokenMethod and
      this.asExpr() = ma.getQualifier()
    )
  }
}


from DataFlow::PathNode sink
where sink.getNode() instanceof JwtTokenSink 
select  
      sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "HardcodedJwtKey"
