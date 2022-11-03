---
layout: post
title: Pretty Printing GeoTools filters
date: 2022-01-21
categories: geotools
---

# Pretty Printing GeoTools filters

The other week I had a need to print out some GeoTools filter objects and while converting them to OGC XML or 
ECQL is relatively easy, neither of those were what I was looking for. I wanted a nicely formatted tree view 
of the filter. Something like:


~~~txt
EqualTo
  ├──"STATE_ABBR"
  └──PA
~~~

Now normally going through and adding some code to add new functionality to all the filters that GeoTools 
supports (ideally including functions that other people wrote) would be a lot of work and very error prone. 
Fortunately, the GeoTools developers were smart and made `Filter` (and `Expression`) objects implement the 
[*Visitor* pattern](https://en.wikipedia.org/wiki/Visitor_pattern). If you know all about design patterns then 
you can skip the next paragraph.

If you've not come across design patterns before then you probably have no idea what I'm talking about. To put 
it simply this design pattern allows you to add virtual methods to a class. In practice this means that each 
`Filter` and `Expression` has an `accept` method that takes a `FilterVisitor` (or `ExpressionVisitor`) and an 
object of (optional) extra data. All this method does is call the visitor's `visit` method with itself as an 
argument (and the extra data). This means that all the complicated work of printing the filter out can be 
implemented in the `PrintFilter` class (which implements `FilterVisitor` and `ExpressionVisitor` via the 
abstract `DefaultFilterVisitor` class). This gives us a default implementation of a `visit` method for each 
type of `Filter` and `Expression` that we are likely to encounter. 

So, now that we have a way to visit each filter and expression in our filter all we need to do is work out how 
to print them out. A quick Google found me a [blog 
post](https://www.baeldung.com/java-print-binary-tree-diagram) about how to print a binary tree in Java. This 
boils down to traversing the tree in *pre-order*, which is a computer sciencey way of saying we want to handle 
each node before we deal with it's children. So we need to print the value of the node and then visit each of 
it's children to get them to print themselves (and their children if needed). This turns out to be pretty 
easy, let's consider the two easiest filters to start with `INCLUDE` and `EXCLUDE` (these constants return all 
features and no features respectively).

~~~java
  @Override
  public Object visit(ExcludeFilter filter, Object data) {
    tree.append("NONE");
    return null;
  }

  @Override
  public Object visit(IncludeFilter filter, Object data) {
    tree.append("ALL");
    return null;
  }
~~~

We know they can have no children so there is no need to do anything other than add their name to the 
`StringBuilder` (`tree`) which we are using to create the output tree. This is actually too simple as we'll 
see when we get to some more complex filters, but it will do for now. If we add some setup to our class we can 
test it.

~~~java
  private StringBuilder tree = new StringBuilder();

  public String print(Filter filter) {
    // traverse the tree in pre-order creating a string
    tree = new StringBuilder();
    filter.accept(this, null);
    return tree.toString();
  }
~~~

So a call to `PrintFilter.print(Filter.INCLUDE)` will print `ALL`. But to make our tree work out we need to 
pass in some other information, like how far to pad the text in and some information to work out which pointer 
to use for the "left" node (the first line can either be `├──` or  `└──` depending on if there is a 2nd (or 
3rd) child to be printed. Fortunately, our `accept` (and `visit`) functions take an optional `Object` data 
object, so we can create an `Object array` to contain the amount we are indented, how much padding we are 
using and if this node has a "right" hand element. This means we need to go back and modify the 
`IncludeFilter` and `ExcludeFilter` methods, but first lets try a simple equality filter to make sure we 
understand how to make the tree work.

~~~java
  private Object visit(PropertyIsEqualTo filter,  Object data) {
    String padding = "";
    String pointer = "";
    boolean right = false;
    if (data != null) {
      pointer = (String) ((Object[]) data)[0];
      padding = (String) ((Object[]) data)[1];
      right = (boolean) ((Object[]) data)[2];
    }
    tree.append("\n");
    tree.append(padding);
    if (pointer != null)
      tree.append(pointer);
    tree.append(PropertyIsEqualTo.NAME);

    StringBuilder paddingBuilder = new StringBuilder(padding);
    if (!first) {
      if (right) {
        paddingBuilder.append("│  ");
      } else {
        paddingBuilder.append("   ");
      }
    }
    first = false;
    padding = paddingBuilder.toString();
    String pointerForRight = "└──";
    String pointerForLeft = (right) ? "├──" : "└──";
    Expression leftE = filter.getExpression1();
    data = leftE.accept(this, new Object[] { pointerForLeft, pointerForRight , true });
    Expression rightE = filter.getExpression2();
    data = rightE.accept(this, new Object[] { pointerForLeft, pointerForRight, false });
    return data;
  }
~~~

First we set some default values if there is no data provided, and if there is data then we unpack it into 
some variables with better names. Then we add a newline (`\n`) and the right amount of padding and then if 
there was a "pointer" passed in we append that. Now we print the name of the `Filter` in this case 
`PropertyIsEqualTo`. Then we add the "down stroke" (unless we're printing the first node of the filter using 
the new `first` variable) and some spacing to the `padding` string. Finally, for this filter we fetch it's 
children using the `getExpression1` and `getExpression2` methods. It's worth noting that many of the GeoTools 
developers are dyslexic so using left and right is tricky. Then to print the children we call their `accept` 
method with the printer class and the needed data to repeat the process. So before we can test this method we 
need to implement at least 1 and probably 2 more methods. So here is how to visit an `PropertyName` expression 
and a `Literal` expression:

~~~java
  @Override
  public Object visit(PropertyName expression, Object data) {
    String padding = "";
    String pointer = "";
    boolean right = false;
    if (data != null) {
      pointer = (String) ((Object[]) data)[0];
      padding = (String) ((Object[]) data)[1];
      right = (boolean) ((Object[]) data)[2];
    }
    data = printNode("\"" + expression.getPropertyName() + "\"", pointer, padding, right);
    return data;
  }
~~~

~~~java
  @Override
  public Object visit(Literal expression, Object data) {
    String padding = "";
    String pointer = "";
    boolean right = false;
    if (data != null) {
      pointer = (String) ((Object[]) data)[0];
      padding = (String) ((Object[]) data)[1];
      right = (boolean) ((Object[]) data)[2];
    }
    data = printNode(expression.getValue().toString(), pointer, padding, right);
    return data;
  }
~~~

You'll notice that these look very similar (and much shorter), I've refactored a little and introduced a 
`printNode` method as it turns out that printing out the padding, pointers and such like is always the same, 
so now all I need is decide what to print out each time and pass in the current pointer, padding string and if 
there is right hand child. Then we just need to call the new method with the value of the `PropertyName` and 
the value of the `Literal` expression.

~~~java
  private String[] printNode(String value, String pointer, String padding,
    boolean right) {
    if (value != null) {
      tree.append("\n");
      tree.append(padding);
      if (pointer != null)
        tree.append(pointer);
      tree.append(value);

      StringBuilder paddingBuilder = new StringBuilder(padding);
      if (!first) {
        if (right) {
          paddingBuilder.append("│  ");
        } else {
          paddingBuilder.append("   ");
        }
      }
      first = false;
      padding = paddingBuilder.toString();
      String pointerForRight = "└──";
      String pointerForLeft = (right) ? "├──" : "└──";
      return new String[] { pointerForLeft, pointerForRight, padding };
    }
    return new String[] {};
  }
~~~

Even with this new shortcut there seems to be a lot of cut and paste needed to write a `visit` method for each 
type of `Filter` there is. Again, the GeoTools developers have your back (and are lazy themselves) so there 
are interfaces that define the groups of filters that you will encounter: 

+ `BinaryComparisonOperator` for all the filters that compare two expressions,
+ `BinarySpatialOperator` for spatial operations,
+ `BinaryExpression` for mathematical operations,
+ `BinaryLogicOperator` for logic operations and
+ `BinaryTemporalOperator` for temporal filters.

We can get away with writing just 5 methods for the 5 groups and then add a few others for special cases, and 
in fact each of the methods is pretty much the same. 

~~~java
  private Object printComparision(BinaryComparisonOperator filter, String name, Object data) {
    String padding = "";
    String pointer = "";
    boolean right = false;
    if (data != null) {
      pointer = (String) ((Object[]) data)[0];
      padding = (String) ((Object[]) data)[1];
      right = (boolean) ((Object[]) data)[2];
    }
    String[] pointers = printNode(name, pointer, padding, right);
    Expression leftE = filter.getExpression1();
    data = leftE.accept(this, new Object[] { pointers[0], pointers[2], true });
    Expression rightE = filter.getExpression2();
    data = rightE.accept(this, new Object[] { pointers[1], pointers[2], false });
    return data;
  }
~~~

Now, our method to handle `PropertyIsEqualTo` becomes just:

~~~java
  @Override
  public Object visit(PropertyIsEqualTo filter, Object data) {
    return printComparision(filter, PropertyIsEqualTo.NAME, data);
  }
~~~

One of the "special" cases is printing out a `Function`, I decided that I wanted the name of the function 
followed by each parameter (which are `Expression`s) on it's own line: 

~~~java
  @Override
  public Object visit(Function expression, Object data) {
    String padding = "";
    String pointer = "";
    boolean right = false;
    if (data != null) {
      pointer = (String) ((Object[]) data)[0];
      padding = (String) ((Object[]) data)[1];
      right = (boolean) ((Object[]) data)[2];
    }
    data = printNode(expression.getName(), pointer, padding, right);
    String pointerL = ((String[]) data)[0];
    String pointerR = ((String[]) data)[1];
    padding = ((String[]) data)[2];
    List<Expression> params = expression.getParameters();
    int last = params.size();
    for (Expression f : params) {
      if (--last == 0) {
        data = f.accept(this, new Object[] { pointerR, padding, false });
      } else {
        data = f.accept(this, new Object[] { pointerL, padding, true });
      }
    }
    return data;
  }
~~~

Here the only trick is to work out when we are the last parameter so we can let the visitor know there is no 
"right" hand child to follow. Once all the necessary `visit` methods are complete we can print out filters as 
complex as we want.

~~~txt
GreaterThan
  ├──"STATE_ABBR"
  └──Add
     └──Mul
     │  ├──10.0
     │  └──2.0
     └──Sub
        └──Add
        │  ├──10.0
        │  └──7.0
        └──23.0
~~~


The full code is available as a [snippet on gitlab](https://gitlab.com/-/snippets/2239721).
