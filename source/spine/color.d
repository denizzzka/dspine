module spine.color;

struct spColor
{
    float r=0, g=0, b=0, a=0;

    spColor opOpAssign(string op)(spColor c)
    if(op == "*")
    {
	r *= c.r;
	g *= c.g;
	b *= c.b;
	a *= c.a;

	return this;
    }

    spColor opOpAssign(string op)(float f)
    if(op == "*")
    {
	r *= f;
	g *= f;
	b *= f;
	a *= f;

	return this;
    }
}
