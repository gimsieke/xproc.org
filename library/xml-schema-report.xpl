<p:declare-step version='1.0' name="main" type="l:xml-schema-report"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:l="http://xproc.org/library">
  <p:input port="source" primary="true"/>
  <p:input port="schema" sequence="true"/>
  <p:output port="result" primary="true"/>
  <p:output port="report" sequence="true">
    <p:pipe step="try" port="report"/>
  </p:output>
  <p:option name="use-location-hints" select="'false'"/>
  <p:option name="try-namespaces" select="'false'"/>
  <p:option name="mode" select="'strict'"/>
  <p:option name="assert-valid" select="'false'"/> <!-- yes, false by default! -->

  <p:try name="try">
    <p:group>
      <p:output port="result" primary="true">
        <p:pipe step="v-xsd" port="result"/>
      </p:output>
      <p:output port="report">
        <p:empty/>
      </p:output>

      <p:validate-with-xml-schema name="v-xsd" assert-valid="true">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="schema">
          <p:pipe step="main" port="schema"/>
        </p:input>
        <p:with-option name="use-location-hints" select="$use-location-hints"/>
        <p:with-option name="try-namespaces" select="$try-namespaces"/>
        <p:with-option name="mode" select="$mode"/>
      </p:validate-with-xml-schema>
    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true">
        <p:pipe step="copy-source" port="result"/>
      </p:output>
      <p:output port="report">
        <p:pipe step="copy-errors" port="result"/>
      </p:output>
      <p:identity name="copy-source">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </p:identity>
      <p:identity name="copy-errors">
        <p:input port="source">
          <p:pipe step="catch" port="error"/>
        </p:input>
      </p:identity>
    </p:catch>
  </p:try>

  <p:count name="count">
    <p:input port="source">
      <p:pipe step="try" port="report"/>
    </p:input>
  </p:count>

  <p:choose>
    <p:when test="$assert-valid = 'true' and /c:result != '0'">
      <!-- This isn't very efficient, but it's an error case so that's
           probably ok. In any event, it assures that l:xml-schema-report
           raises the same errors that the validation raises. -->
      <p:validate-with-xml-schema name="v-rng" assert-valid="true">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="schema">
          <p:pipe step="main" port="schema"/>
        </p:input>
        <p:with-option name="use-location-hints" select="$use-location-hints"/>
        <p:with-option name="try-namespaces" select="$try-namespaces"/>
        <p:with-option name="mode" select="$mode"/>
      </p:validate-with-xml-schema>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:pipe step="try" port="result"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

</p:declare-step>
