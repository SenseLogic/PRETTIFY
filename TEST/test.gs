operator=(
vector
other_vector:REFERENCE[VECTOR_2[_COMPONENT_]]
)
{
assert(?vector!= ?other_vector);

vector.X=other_vector.X;
}
