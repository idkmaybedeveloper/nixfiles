# nixpkgs builds dotnet from the VMR (the "source build"), and on darwin that
# pulls in swift-5.10.1, which means compiling llvm + swift from source for
# four fucking hours
#
# microsoft ships perfectly good tarballs and nixpkgs packages them as the
# `-bin` variants, so point every consumer at those instead
#
# ref: pkgs/development/compilers/dotnet
final: prev: {
  dotnetCorePackages = prev.dotnetCorePackages // {
    sdk_8_0 = prev.dotnetCorePackages.sdk_8_0-bin;
    sdk_9_0 = prev.dotnetCorePackages.sdk_9_0-bin;
    sdk_10_0 = prev.dotnetCorePackages.sdk_10_0-bin;
    runtime_8_0 = prev.dotnetCorePackages.runtime_8_0-bin;
    runtime_9_0 = prev.dotnetCorePackages.runtime_9_0-bin;
    runtime_10_0 = prev.dotnetCorePackages.runtime_10_0-bin;
    aspnetcore_8_0 = prev.dotnetCorePackages.aspnetcore_8_0-bin;
    aspnetcore_9_0 = prev.dotnetCorePackages.aspnetcore_9_0-bin;
    aspnetcore_10_0 = prev.dotnetCorePackages.aspnetcore_10_0-bin;
  };
}
