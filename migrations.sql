
   Illuminate\Database\QueryException 

  could not find driver (Connection: pgsql, SQL: select exists (select 1 from pg_class c, pg_namespace n where n.nspname = current_schema() and c.relname = 'migrations' and c.relkind in ('r', 'p') and n.oid = c.relnamespace))

  at vendor\laravel\framework\src\Illuminate\Database\Connection.php:823
    819Ôûò                     $this->getName(), $query, $this->prepareBindings($bindings), $e
    820Ôûò                 );
    821Ôûò             }
    822Ôûò 
  Ô×£ 823Ôûò             throw new QueryException(
    824Ôûò                 $this->getName(), $query, $this->prepareBindings($bindings), $e
    825Ôûò             );
    826Ôûò         }
    827Ôûò     }

  1   vendor\laravel\framework\src\Illuminate\Database\Connectors\Connector.php:66
      PDOException::("could not find driver")

  2   vendor\laravel\framework\src\Illuminate\Database\Connectors\Connector.php:66
      PDO::__construct("pgsql:host=https://nzlqddfsbksqwbjebjgy.supabase.co;dbname='postgres';port=5432;client_encoding='utf8';sslmode=require", "postgres", Object(SensitiveParameterValue), [])

