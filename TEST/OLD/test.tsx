type Props = { name: string; kind: string };

export function DemoTsx( props: Props )
{
return (
<>
<Foo.Bar data-a={ 1 + 2 } />
<div className={ `x-${props.kind}` }>
Hello { props.name }
</div>
</>
);
}
