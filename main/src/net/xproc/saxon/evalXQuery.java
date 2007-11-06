package net.xproc.saxon;

import javax.xml.xpath.XPathException;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.om.Axis;
import net.sf.saxon.om.AxisIterator;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NamePool;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.pattern.NodeKindTest;
import net.sf.saxon.query.DynamicQueryContext;
import net.sf.saxon.query.StaticQueryContext;
import net.sf.saxon.query.XQueryExpression;
import net.sf.saxon.type.Type;
import net.sf.saxon.value.Value;


public class evalXQuery {


/**
     * Compile a string containing a source query
     * @param context the XPath dynamic evaluation context
     * @param query a string containing the query to be compiled
     * @return the compiled query
     */
    public static XQueryExpression compileQuery(XPathContext context, String query) throws XPathException, net.sf.saxon.trans.XPathException {
        if (query == null) {
            return null;
        }
        StaticQueryContext sqc = new StaticQueryContext(context.getConfiguration());
        return sqc.compileQuery(query);
    }

/**
     * Run a previously-compiled query
     * @param context The dynamic context
     * @param query The compiled query
     * @return the sequence representing the result of the query
     */
    public static SequenceIterator query(XPathContext context, XQueryExpression query) throws XPathException, net.sf.saxon.trans.XPathException {
        if (query == null) {
            return null;
        }
        DynamicQueryContext dqc = new DynamicQueryContext(context.getConfiguration());
        return query.iterator(dqc);
    }

/**
     * Run a previously-compiled query
     * @param context The dynamic context
     * @param query The compiled query
     * @param source The initial context item for the query (may be null)
     * @return the sequence representing the result of the query
     */
    public static SequenceIterator query(XPathContext context, XQueryExpression query, Item source) throws XPathException, net.sf.saxon.trans.XPathException {
        if (query == null) {
            return null;
        }
        DynamicQueryContext dqc = new DynamicQueryContext(context.getConfiguration());
        if (source != null) {
            dqc.setContextItem(source);
        }
        return query.iterator(dqc);
    }

/**
     * Run a previously-compiled query, supplying parameters to the
     * transformation.
     * @param context The dynamic context
     * @param query The compiled query
     * @param source The initial context node for the query (may be null)
     * @param params A sequence of nodes (typically element nodes) supplying values of parameters.
     * The name of the node should match the name of the parameter, the typed value of the node is
     * used as the value of the parameter.
     * @return the results of the query (a sequence of items)
     */
    public static SequenceIterator query(XPathContext context, XQueryExpression query, Item source, SequenceIterator params) throws XPathException, net.sf.saxon.trans.XPathException {
        if (query == null) {
            return null;
        }

        DynamicQueryContext dqc = new DynamicQueryContext(context.getConfiguration());
        if (source != null) {
            dqc.setContextItem(source);
        }

        NamePool pool = context.getConfiguration().getNamePool();
        while (true) {
            Item param = params.next();
            if (param == null) {
                break;
            }

            if (param instanceof NodeInfo) {
                switch (((NodeInfo) param).getNodeKind()) {
                    case Type.ELEMENT:
                    case Type.ATTRIBUTE:
                        Value val = ((NodeInfo) param).atomize();
                        dqc.setParameter(pool.getClarkName(((NodeInfo) param).getNameCode()), val);
                        break;
                    case Type.DOCUMENT:
                        AxisIterator kids = ((NodeInfo) param).iterateAxis(Axis.CHILD, NodeKindTest.ELEMENT);
                        while (true) {
                            NodeInfo kid = (NodeInfo) kids.next();
                            if (kid == null) {
                                break;
                            }
                            Value val2 = ((NodeInfo) param).atomize();
                            dqc.setParameter(pool.getClarkName(kid.getNameCode()), val2);
                        }
                        break;
                    default:
                        throw new XPathException("Parameters passed to saxon:query() must be element, attribute, or document nodes");
                }
            } else {
                throw new XPathException("Parameters passed to saxon:query() must be nodes");
            }
        }
        return query.iterator(dqc);
    }
}