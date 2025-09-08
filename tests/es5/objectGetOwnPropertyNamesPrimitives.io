> try { Object.getOwnPropertyNames(1); print(false); } catch (e) { print(e instanceof TypeError); }
> try { Object.getOwnPropertyNames('x'); print(false); } catch (e) { print(e instanceof TypeError); }
> try { Object.getOwnPropertyNames(true); print(false); } catch (e) { print(e instanceof TypeError); }
> try { Object.getOwnPropertyNames(null); print(false); } catch (e) { print(e instanceof TypeError); }
> try { Object.getOwnPropertyNames(undefined); print(false); } catch (e) { print(e instanceof TypeError); }
