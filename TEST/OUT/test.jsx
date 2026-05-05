export function Demo( props )
{
    return (
        <>
            <Foo.Bar id="x" data-a={ 1 + 2 } {...props} />
            <svg:path d="M0 0L10 10" />
            <div className={ `x-${props.kind}` }>
        Hello
                {
                    props.name
                }
            </div>
        </>
        );
}
