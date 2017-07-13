defmodule ChordDht do
  import Ecto.Query, except: [preload: 2]
  import ChordDht.Repo
  alias ChordDht.Node

  @moduledoc """
  Documentation for ChordDht.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ChordDht.hello
      :world

  """
  
  def hello do
    :world
  end
  
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ChordDht.Repo, []),
    ]

    opts = [strategy: :one_for_one, name: ChordDht.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def makehash(str) do #ハッシュ計算を行う
    :crypto.hash(:sha256,str)
      |> Base.encode16(case: :lower) 
      
  end

  def mklist(str) do
    hashedstr = makehash(str)
     _mklist([hashedstr],hashedstr) #与えられた引数を元にリストを作成
  end

  defp _mklist(list,_) when length(list)>=4, do: list
 
  defp _mklist(list,str) when length(list)<4 do
    head = makehash(str)
    _mklist([head|list],head)
  end


  def init(str) do #DBの初期化 実行はmix run -e 'ChordDht.init("moji")'
    delete_all Node
    strseed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    Enum.each(mklist(str),fn (hash) ->
        nodename_list = String.codepoints(strseed)
                        |> Enum.take_random(30)
        nodename = Enum.join(nodename_list)
        insert(%Node{name: nodename,ip: "12345",hash: hash,successor: "nil",predecessor: "nil"})

      end
    )
    nd = Node |> all
    Enum.each(nd,fn (n) ->
      IO.puts n.name
    end
    )
    IO.inspect nd
  end
end
